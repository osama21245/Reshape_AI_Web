import Header from "./_components/Header";

function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-black text-white">
      <Header />
      <main className="pt-16 min-h-screen bg-gradient-to-b from-black via-purple-900/20 to-black">
        <div className="max-w-7xl mx-auto px-4 py-8">
          {children}
        </div>
      </main>
    </div>
  );
}

export default DashboardLayout;
