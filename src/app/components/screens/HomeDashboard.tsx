import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Search,
  MapPin,
  Navigation,
  AlertTriangle,
  Building2,
  GraduationCap,
  Calculator,
} from "lucide-react";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Card } from "../ui/card";

export function HomeDashboard() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");

  const quickActions = [
    {
      icon: Navigation,
      label: "Explore My Location",
      color: "bg-blue-500",
      action: () => navigate("/location/current"),
    },
    {
      icon: AlertTriangle,
      label: "Hazard Assessment",
      color: "bg-orange",
      action: () => navigate("/location/current"),
    },
    {
      icon: Building2,
      label: "House Models",
      color: "bg-[#0f172a]",
      action: () => navigate("/models"),
    },
    {
      icon: GraduationCap,
      label: "Construction Academy",
      color: "bg-green-600",
      action: () => navigate("/academy"),
    },
    {
      icon: Calculator,
      label: "Resilience Calculator",
      color: "bg-purple-600",
      action: () => navigate("/location/current"),
    },
  ];

  return (
    <div className="h-full w-full flex flex-col bg-background">
      <div className="relative h-[50vh] bg-gradient-to-br from-[#0f172a] to-[#334155]">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxkZWZzPjxwYXR0ZXJuIGlkPSJncmlkIiB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHBhdHRlcm5Vbml0cz0idXNlclNwYWNlT25Vc2UiPjxwYXRoIGQ9Ik0gNDAgMCBMIDAgMCAwIDQwIiBmaWxsPSJub25lIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjAuNSIgb3BhY2l0eT0iMC4xIi8+PC9wYXR0ZXJuPjwvZGVmcz48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ1cmwoI2dyaWQpIi8+PC9zdmc+')] opacity-30"></div>

        <div className="absolute top-4 left-4 right-4 z-10">
          <div className="bg-white/95 backdrop-blur-md rounded-2xl shadow-xl p-4 flex items-center gap-3">
            <Search className="h-5 w-5 text-muted-foreground" />
            <Input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Where do you want to build?"
              className="border-0 bg-transparent focus-visible:ring-0 text-base"
            />
            <MapPin className="h-5 w-5 text-orange cursor-pointer" />
          </div>
        </div>

        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center text-white space-y-2">
            <MapPin className="h-16 w-16 mx-auto text-orange mb-4" />
            <p className="text-lg">Tap the map or search to select location</p>
            <Button
              onClick={() => navigate("/location/current")}
              variant="outline"
              className="bg-white/10 backdrop-blur-md border-white/20 text-white hover:bg-white/20 mt-4"
            >
              <Navigation className="mr-2 h-4 w-4" />
              Use My Location
            </Button>
          </div>
        </div>
      </div>

      <div className="flex-1 bg-background -mt-6 rounded-t-3xl relative z-10">
        <div className="p-6 space-y-6">
          <div>
            <h2 className="text-xl font-bold mb-4">Quick Actions</h2>
            <div className="grid grid-cols-2 gap-4">
              {quickActions.map((action, index) => {
                const Icon = action.icon;
                return (
                  <Card
                    key={index}
                    onClick={action.action}
                    className="p-6 cursor-pointer hover:shadow-lg transition-all border-2 hover:border-accent"
                  >
                    <div className="flex flex-col items-center text-center gap-3">
                      <div className={`${action.color} p-4 rounded-2xl`}>
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <span className="text-sm font-medium leading-tight">
                        {action.label}
                      </span>
                    </div>
                  </Card>
                );
              })}
            </div>
          </div>

          <Card className="p-6 bg-gradient-to-br from-orange/10 to-orange/5 border-orange/20">
            <div className="flex items-start gap-4">
              <div className="bg-orange p-3 rounded-xl">
                <AlertTriangle className="h-6 w-6 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="font-bold mb-1">Build with Confidence</h3>
                <p className="text-sm text-muted-foreground">
                  Get location-specific construction guidance for flood, earthquake, and landslide prone areas
                </p>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
