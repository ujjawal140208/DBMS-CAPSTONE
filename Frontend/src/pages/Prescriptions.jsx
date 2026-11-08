import ResourcePage from './ResourcePage';
export default function Prescriptions(){return <ResourcePage title='Prescriptions' endpoint='/prescriptions' columns={[{key:'id',label:'ID'},{key:'patient_id',label:'Patient ID'},{key:'doctor_id',label:'Doctor ID'},{key:'prescribed_at',label:'Date'}]}/>}
