import { Outlet, useLocation, useNavigate } from "react-router";
import { Home, BookOpen, FolderKanban, User, Layers } from "lucide-react";
import { Toaster } from "../ui/sonner";

export function RootLayout() {
  const location = useLocation();
  const navigate = useNavigate();

  const hideNavigation = location.pathname === "/" || location.pathname === "/onboarding";

  const navItems = [
    { path: "/home", icon: Home, label: "Home" },
    { path: "/models", icon: Layers, label: "Models" },
    { path: "/academy", icon: BookOpen, label: "Academy" },
    { path: "/projects", icon: FolderKanban, label: "Projects" },
    { path: "/profile", icon: User, label: "Profile" },
  ];

  return (
    <div className="flex flex-col h-screen bg-background">
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>

      {!hideNavigation && (
        <nav className="border-t border-border bg-card/95 backdrop-blur-md">
          <div className="flex justify-around items-center h-16 max-w-screen-md mx-auto px-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname.startsWith(item.path);

              return (
                <button
                  key={item.path}
                  onClick={() => navigate(item.path)}
                  className={`flex flex-col items-center justify-center gap-1 px-4 py-2 rounded-lg transition-all ${
                    isActive
                      ? "text-accent"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  <Icon className={`h-5 w-5 ${isActive ? "fill-accent" : ""}`} />
                  <span className="text-[10px]">{item.label}</span>
                </button>
              );
            })}
          </div>
        </nav>
      )}
      <Toaster />
    </div>
  );
}
