import Header from "../components/Header";

function About() {
	return (
		<div className="min-h-screen bg-white text-slate-900 dark:bg-slate-900 dark:text-white">
			<Header />

			<main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
				<p>About</p>
			</main>
		</div>
	);
}

export default About;
