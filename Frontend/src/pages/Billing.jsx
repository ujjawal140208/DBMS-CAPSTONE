import ResourcePage from './ResourcePage';
export default function Billing(){return <ResourcePage title='Billing' endpoint='/bills' columns={[{key:'id',label:'Bill ID'},{key:'patient_id',label:'Patient ID'},{key:'bill_date',label:'Date'},{key:'total_amount',label:'Total'},{key:'status',label:'Status'}]}/>}
