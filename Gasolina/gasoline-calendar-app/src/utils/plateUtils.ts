export const getScheduleByPlate = (plate: string): string[] => {
    const lastDigit = plate.slice(-1);
    const schedules: { [key: string]: string[] } = {
        '0': ['Monday', 'Wednesday', 'Friday'],
        '1': ['Monday', 'Wednesday', 'Friday'],
        '2': ['Tuesday', 'Thursday'],
        '3': ['Tuesday', 'Thursday'],
        '4': ['Monday', 'Wednesday', 'Friday'],
        '5': ['Monday', 'Wednesday', 'Friday'],
        '6': ['Tuesday', 'Thursday'],
        '7': ['Tuesday', 'Thursday'],
        '8': ['Monday', 'Wednesday', 'Friday'],
        '9': ['Monday', 'Wednesday', 'Friday'],
    };

    return schedules[lastDigit] || [];
};