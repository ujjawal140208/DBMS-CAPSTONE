import ResourcePage from './ResourcePage';
export default function Medicines(){return <ResourcePage title='Medicines' endpoint='/medicines' columns={[{key:'id',label:'ID'},{key:'name',label:'Medicine'},{key:'category',label:'Category'},{key:'unit_price',label:'Unit price'}]}/>}
