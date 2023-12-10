import { h, Component } from 'preact';

import { ITerminalOptions, ITheme } from 'xterm';
import { ClientOptions, FlowControl } from './terminal/xterm';
import { Terminal } from './terminal';
import { useState } from 'preact/compat';
import { Modal } from './modal';

const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
const path = window.location.pathname.replace(/[/]+$/, '');
const wsUrl = [protocol, '//', window.location.host, path, '/ws', window.location.search].join('');
const tokenUrl = [window.location.protocol, '//', window.location.host, path, '/token'].join('');
const clientOptions = {
    rendererType: 'webgl',
    disableLeaveAlert: false,
    disableResizeOverlay: false,
    enableZmodem: false,
    enableTrzsz: false,
    enableSixel: false,
    isWindows: false,
} as ClientOptions;
const termOptions = {
    fontSize: 13,
    fontFamily: 'Consolas,Liberation Mono,Menlo,Courier,monospace',
    theme: {
        foreground: '#d2d2d2',
        background: '#2b2b2b',
        cursor: '#adadad',
        black: '#000000',
        red: '#d81e00',
        green: '#5ea702',
        yellow: '#cfae00',
        blue: '#427ab3',
        magenta: '#89658e',
        cyan: '#00a7aa',
        white: '#dbded8',
        brightBlack: '#686a66',
        brightRed: '#f54235',
        brightGreen: '#99e343',
        brightYellow: '#fdeb61',
        brightBlue: '#84b0d8',
        brightMagenta: '#bc94b7',
        brightCyan: '#37e6e8',
        brightWhite: '#f1f1f0',
    } as ITheme,
    allowProposedApi: true,
} as ITerminalOptions;
const flowControl = {
    limit: 100000,
    highWater: 10,
    lowWater: 4,
} as FlowControl;

export class App extends Component {
    sleep(ms: number) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    render() {
        const [show, setShow] = useState(false);
        const [text, setText] = useState('echo "hello world"');
        return (
            <div style={{ width: '100vw', height: '100vh' }}>
                {show ? (
                    <Terminal
                        id="terminal-container"
                        wsUrl={wsUrl}
                        tokenUrl={tokenUrl}
                        clientOptions={clientOptions}
                        termOptions={termOptions}
                        flowControl={flowControl}
                    />
                ) : (
                    <Modal show={true}>
                        <h1>Init Command</h1>
                        <form
                            onSubmit={async e => {
                                e.preventDefault();
                                setShow(true);
                                while (!window.term || !window.term.paste || typeof window.term.paste !== 'function') {
                                    await this.sleep(300);
                                }
                                window.term.focus();
                                window.term.paste(text);
                                const terminal = document.querySelector('textarea.xterm-helper-textarea');
                                if (terminal) {
                                    terminal.dispatchEvent(new KeyboardEvent('keypress', { charCode: 13 }));
                                }
                                window.term.fit();
                            }}
                        >
                            <label>
                                <textarea
                                    type="text"
                                    value={text}
                                    onChange={e => {
                                        const target = e.target as HTMLInputElement;
                                        setText(target.value);
                                    }}
                                />
                            </label>
                            <input type="submit" value="Submit" />
                        </form>
                    </Modal>
                )}
            </div>
        );
    }
}
