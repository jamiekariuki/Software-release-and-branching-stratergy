
import { useState} from 'react'
import './App.scss'
import Appv1 from './components/appv1/appv1'
import Appv2 from './components/appv2/appv2'

function App() {
  const [version, setVersion]= useState("v1.3.9")
  
  useEffect(() => {
    setVersion(window._env_?.VERSION || "v0.0.0")
  }, [])
  
  return (
  <div className='appN'>
  <h1>{version}</h1>
   <Appv1/> 
   {/*  <Appv2/> */}
  </div>
  )
}

export default App
