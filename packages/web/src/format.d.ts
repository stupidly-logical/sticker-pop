export type PopSign = 'auto' | 'always' | 'none';
export declare function groupIndian(value: number): string;
export declare function formatInr(paise: number, options?: { sign?: PopSign; alwaysPaise?: boolean }): string;
export declare function formatInrCompact(paise: number, options?: { sign?: PopSign }): string;
export declare function formatPopDate(date: Date, now?: Date): string;
export declare function formatPopMonth(date: Date): string;
export declare function formatPopTime(date: Date): string;
