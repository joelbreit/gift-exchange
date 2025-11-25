import {
	LineChart,
	Line,
	XAxis,
	YAxis,
	CartesianGrid,
	Tooltip,
	Legend,
	ResponsiveContainer,
} from "recharts";
import Header from "../components/Header";

function Dashboard() {
	return (
		<div className="min-h-screen bg-white text-slate-900 dark:bg-slate-900 dark:text-white">
			<Header />

			<main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
				<p>Dashboard</p>
			</main>
		</div>
	);
}

export default Dashboard;
