export interface Schedule {
    day: string;
    plateEnding: number;
}

export interface PlateSchedule {
    plateEnding: number;
    schedule: string[];
}