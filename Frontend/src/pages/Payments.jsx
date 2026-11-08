import ResourcePage from './ResourcePage';
export default function Payments(){return <ResourcePage title='Payments' endpoint='/payments' columns={[{key:'id',label:'Payment ID'},{key:'bill_id',label:'Bill ID'},{key:'amount',label:'Amount'},{key:'method',label:'Method'},{key:'payment_date',label:'Date'}]}/>}
