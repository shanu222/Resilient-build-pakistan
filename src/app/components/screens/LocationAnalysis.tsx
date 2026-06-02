import { useNavigate } from "react-router";
import {
  Waves,
  Mountain,
  Wind,
  Activity,
  Droplets,
  MapPin,
  ChevronRight,
} from "lucide-react";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Progress } from "../ui/progress";

export function LocationAnalysis() {
  const navigate = useNavigate();

  const risks = [
    {
      type: "Flood Risk",
      level: "High",
      score: 75,
      icon: Waves,
      color: "text-blue-600",
      bgColor: "bg-blue-50",
      barColor: "bg-blue-600",
    },
    {
      type: "Earthquake Risk",
      level: "Medium",
      score: 45,
      icon: Activity,
      color: "text-orange",
      bgColor: "bg-orange/10",
      barColor: "bg-orange",
    },
    {
      type: "Landslide Risk",
      level: "Low",
      score: 20,
      icon: Mountain,
      color: "text-green-600",
      bgColor: "bg-green-50",
      barColor: "bg-green-600",
    },
    {
      type: "GLOF Risk",
      level: "Low",
      score: 15,
      icon: Droplets,
      color: "text-cyan-600",
      bgColor: "bg-cyan-50",
      barColor: "bg-cyan-600",
    },
    {
      type: "Wind Risk",
      level: "Medium",
      score: 40,
      icon: Wind,
      color: "text-purple-600",
      bgColor: "bg-purple-50",
      barColor: "bg-purple-600",
    },
  ];

  const suitabilityScore = 68;

  return (
    <div className="h-full w-full bg-background overflow-auto">
      <div className="relative h-48 bg-gradient-to-br from-[#0f172a] to-[#334155]">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxkZWZzPjxwYXR0ZXJuIGlkPSJncmlkIiB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHBhdHRlcm5Vbml0cz0idXNlclNwYWNlT25Vc2UiPjxwYXRoIGQ9Ik0gNDAgMCBMIDAgMCAwIDQwIiBmaWxsPSJub25lIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjAuNSIgb3BhY2l0eT0iMC4xIi8+PC9wYXR0ZXJuPjwvZGVmcz48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ1cmwoI2dyaWQpIi8+PC9zdmc+')] opacity-30"></div>

        <div className="relative h-full flex items-center justify-center text-white">
          <div className="text-center">
            <MapPin className="h-8 w-8 mx-auto mb-2 text-orange" />
            <h1 className="text-xl font-bold">Lahore, Punjab</h1>
            <p className="text-sm text-white/70">31.5204° N, 74.3587° E</p>
          </div>
        </div>
      </div>

      <div className="p-6 space-y-6 -mt-8 relative z-10">
        <Card className="p-6 bg-gradient-to-br from-[#0f172a] to-[#1e293b] text-white shadow-xl">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold">Overall Site Suitability</h2>
            <span className="text-3xl font-bold">{suitabilityScore}%</span>
          </div>
          <Progress value={suitabilityScore} className="h-3 bg-white/20" />
          <p className="text-sm text-white/70 mt-3">
            Moderate suitability with flood mitigation required
          </p>
        </Card>

        <div>
          <h2 className="text-xl font-bold mb-4">Hazard Assessment</h2>
          <div className="space-y-3">
            {risks.map((risk, index) => {
              const Icon = risk.icon;
              return (
                <Card key={index} className="p-4">
                  <div className="flex items-center gap-4">
                    <div className={`${risk.bgColor} p-3 rounded-xl`}>
                      <Icon className={`h-5 w-5 ${risk.color}`} />
                    </div>
                    <div className="flex-1">
                      <div className="flex justify-between items-center mb-2">
                        <span className="font-medium">{risk.type}</span>
                        <span
                          className={`text-sm font-bold ${
                            risk.level === "High"
                              ? "text-red-600"
                              : risk.level === "Medium"
                              ? "text-orange"
                              : "text-green-600"
                          }`}
                        >
                          {risk.level}
                        </span>
                      </div>
                      <Progress
                        value={risk.score}
                        className={`h-2 ${risk.bgColor}`}
                      />
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </div>

        <Card className="p-6 border-orange/30 bg-orange/5">
          <h3 className="font-bold mb-2">River Proximity</h3>
          <p className="text-sm text-muted-foreground">
            Located 2.5 km from Ravi River. Monsoon flooding possible.
          </p>
        </Card>

        <Card className="p-6">
          <h3 className="font-bold mb-2">Historical Events</h3>
          <div className="space-y-2 text-sm text-muted-foreground">
            <p>• 2010: Major flood event (water level 5.2m)</p>
            <p>• 2014: Moderate flooding during monsoon</p>
            <p>• 2022: Urban flash floods</p>
          </div>
        </Card>

        <Button
          onClick={() => navigate("/models")}
          className="w-full bg-accent hover:bg-accent/90 text-white py-6 rounded-2xl shadow-lg"
          size="lg"
        >
          View Recommended House Models
          <ChevronRight className="ml-2 h-5 w-5" />
        </Button>
      </div>
    </div>
  );
}
