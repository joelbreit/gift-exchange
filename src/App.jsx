import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import Directory from "./pages/Directory";
import About from "./pages/About";

function App() {
	return (
		<Router>
			<Routes>
				<Route path="/" element={<Dashboard />} />
				<Route path="/directory" element={<Directory />} />
				<Route path="/about" element={<About />} />
			</Routes>
		</Router>
	);
}

export default App;
