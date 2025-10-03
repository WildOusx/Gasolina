import React, { useState } from 'react';
import { schedules } from '../data/schedules';
import { getScheduleByPlate } from '../utils/plateUtils';

const Calendar: React.FC = () => {
    const [plate, setPlate] = useState('');
    const [schedule, setSchedule] = useState<string[]>([]);

    const handlePlateChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const newPlate = event.target.value;
        setPlate(newPlate);
        const newSchedule = getScheduleByPlate(newPlate);
        setSchedule(newSchedule);
    };

    return (
        <div>
            <h1>Calendario de Gasolina</h1>
            <input
                type="text"
                value={plate}
                onChange={handlePlateChange}
                placeholder="Ingrese el número de placa"
            />
            <h2>Horario de Gasolina:</h2>
            <ul>
                {schedule.length > 0 ? (
                    schedule.map((day, index) => <li key={index}>{day}</li>)
                ) : (
                    <li>No hay horario disponible</li>
                )}
            </ul>
        </div>
    );
};

export default Calendar;