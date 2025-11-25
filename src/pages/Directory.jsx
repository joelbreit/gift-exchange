import Header from "../components/Header";

function Directory() {
	return (
		<div className="min-h-screen bg-white font-sans text-slate-900 dark:bg-slate-900 dark:text-white">
			<Header />

			<main className="mx-auto max-w-5xl px-4 py-12 md:px-8 md:py-16">
				<h1 className="text-4xl font-semibold tracking-tight md:text-5xl">
					Directory
				</h1>
				<p className="mt-6 text-base font-normal leading-relaxed md:text-lg">
					View the directory of participants.
				</p>
			</main>
		</div>
	);
}

export default Directory;
