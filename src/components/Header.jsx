import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { Settings, Github, Menu, X } from "lucide-react";

function Header() {
	const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
	const location = useLocation();

	const isActive = (path) => location.pathname === path;

	return (
		<nav className="bg-white font-sans shadow-sm dark:bg-slate-800">
			<div className="mx-auto max-w-5xl px-4 md:px-8">
				<div className="flex h-16 justify-between">
					<div className="flex items-center">
						<div className="shrink-0 text-xl font-semibold">
							Gift Exchange
						</div>

						{/* Desktop navigation */}
						<div className="hidden md:ml-6 md:flex md:space-x-8">
							<Link
								to="/"
								className={`inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
									isActive("/")
										? "border-indigo-500 text-slate-900 dark:text-white"
										: "border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700 dark:text-slate-300 dark:hover:text-white"
								}`}
							>
								Dashboard
							</Link>
							<Link
								to="/directory"
								className={`inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
									isActive("/directory")
										? "border-indigo-500 text-slate-900 dark:text-white"
										: "border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700 dark:text-slate-300 dark:hover:text-white"
								}`}
							>
								Directory
							</Link>
							<Link
								to="/about"
								className={`inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
									isActive("/about")
										? "border-indigo-500 text-slate-900 dark:text-white"
										: "border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700 dark:text-slate-300 dark:hover:text-white"
								}`}
							>
								About
							</Link>
						</div>
					</div>
					<div className="flex items-center gap-2">
						<button className="rounded-full bg-slate-100 p-1 text-slate-500 transition-all duration-150 ease-out hover:-translate-y-0.5 hover:shadow-md hover:text-slate-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 dark:bg-slate-700 dark:text-slate-300 dark:hover:text-white">
							<span className="sr-only">Settings</span>
							<Settings className="h-5 w-5" />
						</button>

						<a
							href="https://github.com"
							className="rounded-full bg-slate-100 p-1 text-slate-500 transition-all duration-150 ease-out hover:-translate-y-0.5 hover:shadow-md hover:text-slate-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 dark:bg-slate-700 dark:text-slate-300 dark:hover:text-white"
						>
							<span className="sr-only">GitHub</span>
							<Github className="h-5 w-5" />
						</a>

						{/* Mobile menu button */}
						<div className="flex items-center md:hidden">
							<button
								type="button"
								className="inline-flex items-center justify-center rounded-full p-2 text-slate-500 transition-all duration-150 ease-out hover:-translate-y-0.5 hover:bg-slate-100 hover:shadow-md hover:text-slate-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 dark:text-slate-300 dark:hover:bg-slate-700 dark:hover:text-white"
								onClick={() =>
									setIsMobileMenuOpen(!isMobileMenuOpen)
								}
							>
								<span className="sr-only">Open main menu</span>
								{isMobileMenuOpen ? (
									<X
										className="block h-6 w-6"
										aria-hidden="true"
									/>
								) : (
									<Menu
										className="block h-6 w-6"
										aria-hidden="true"
									/>
								)}
							</button>
						</div>
					</div>
				</div>
			</div>

			{/* Mobile menu, show/hide based on menu state */}
			{isMobileMenuOpen && (
				<div className="md:hidden">
					<div className="space-y-1 pb-3 pt-2">
						<Link
							to="/"
							className={`block border-l-4 py-2 pl-3 pr-4 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
								isActive("/")
									? "border-indigo-500 bg-indigo-50 text-indigo-700 dark:bg-slate-700 dark:text-white"
									: "border-transparent text-slate-500 hover:border-slate-300 hover:bg-slate-50 hover:text-slate-700 dark:text-slate-300 dark:hover:bg-slate-700 dark:hover:text-white"
							}`}
						>
							Dashboard
						</Link>
						<Link
							to="/directory"
							className={`block border-l-4 py-2 pl-3 pr-4 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
								isActive("/directory")
									? "border-indigo-500 bg-indigo-50 text-indigo-700 dark:bg-slate-700 dark:text-white"
									: "border-transparent text-slate-500 hover:border-slate-300 hover:bg-slate-50 hover:text-slate-700 dark:text-slate-300 dark:hover:bg-slate-700 dark:hover:text-white"
							}`}
						>
							Directory
						</Link>
						<Link
							to="/about"
							className={`block border-l-4 py-2 pl-3 pr-4 text-sm font-medium uppercase tracking-wide transition-all duration-150 ease-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300 ${
								isActive("/about")
									? "border-indigo-500 bg-indigo-50 text-indigo-700 dark:bg-slate-700 dark:text-white"
									: "border-transparent text-slate-500 hover:border-slate-300 hover:bg-slate-50 hover:text-slate-700 dark:text-slate-300 dark:hover:bg-slate-700 dark:hover:text-white"
							}`}
						>
							About
						</Link>
					</div>
				</div>
			)}
		</nav>
	);
}
export default Header;
