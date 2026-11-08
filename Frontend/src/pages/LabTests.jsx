import ResourcePage from './ResourcePage';
export default function LabTests(){return <ResourcePage title='Laboratory tests' endpoint='/lab-tests' columns={[{key:'id',label:'ID'},{key:'name',label:'Test'},{key:'standard_price',label:'Price'},{key:'is_active',label:'Active'}]}/>}
