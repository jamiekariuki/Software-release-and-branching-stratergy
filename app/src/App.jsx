//import { useEffect, useState } from "react";
import "./App.scss";
import Appv1 from "./components/appv1/appv1";
import Appv2 from "./components/appv2/appv2";

function App() {
  return (
    <div className="appN">
      <h1>OUR APP</h1>
      <Appv1 />
      {/*  <Appv2/> */}
    </div>
  );
}

export default App;
