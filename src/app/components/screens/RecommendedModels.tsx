import { useNavigate } from "react-router";
import {
  Waves,
  Activity,
  Mountain,
  Home,
  Droplets,
  Shield,
  DollarSign,
  Wrench,
  ChevronRight,
} from "lucide-react";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Badge } from "../ui/badge";

export function RecommendedModels() {
  const navigate = useNavigate();

  const models = [
    {
      id: "flood-resistant",
      name: "Flood Resilient House",
      icon: Waves,
      color: "bg-blue-600",
      cost: "Medium",
      resilience: 92,
      complexity: "Moderate",
      hazards: ["Flood", "Heavy Rain"],
      image: "bg-gradient-to-br from-blue-500 to-cyan-500",
    },
    {
      id: "earthquake-resistant",
      name: "Earthquake Resistant House",
      icon: Activity,
      color: "bg-orange",
      cost: "High",
      resilience: 88,
      complexity: "Complex",
      hazards: ["Earthquake", "Aftershocks"],
      image: "bg-gradient-to-br from-orange to-amber-500",
    },
    {
      id: "mountain-slope",
      name: "Mountain Slope House",
      icon: Mountain,
      color: "bg-green-600",
      cost: "High",
      resilience: 85,
      complexity: "Complex",
      hazards: ["Landslide", "Heavy Rain"],
      image: "bg-gradient-to-br from-green-600 to-emerald-500",
    },
    {
      id: "hybrid-rcc",
      name: "Hybrid RCC House",
      icon: Shield,
      color: "bg-purple-600",
      cost: "High",
      resilience: 95,
      complexity: "Complex",
      hazards: ["Flood", "Earthquake", "Wind"],
      image: "bg-gradient-to-br from-purple-600 to-violet-500",
    },
    {
      id: "rural-low-cost",
      name: "Rural Low-Cost House",
      icon: Home,
      color: "bg-amber-600",
      cost: "Low",
      resilience: 70,
      complexity: "Simple",
      hazards: ["Moderate Flood"],
      image: "bg-gradient-to-br from-amber-600 to-yellow-500",
    },
    {
      id: "glof-resilient",
      name: "GLOF Resilient House",
      icon: Droplets,
      color: "bg-cyan-600",
      cost: "Very High",
      resilience: 90,
      complexity: "Very Complex",
      hazards: ["GLOF", "Flash Flood", "Debris Flow"],
      image: "bg-gradient-to-br from-cyan-600 to-blue-500",
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">Recommended Models</h1>
        <p className="text-sm text-white/70">
          Based on your location hazard profile
        </p>
      </div>

      <div className="p-6 space-y-4">
        {models.map((model) => {
          const Icon = model.icon;
          return (
            <Card
              key={model.id}
              className="overflow-hidden hover:shadow-xl transition-all cursor-pointer border-2 hover:border-accent"
              onClick={() => navigate(`/model/${model.id}`)}
            >
              <div className="flex gap-4 p-4">
                <div
                  className={`${model.image} rounded-2xl p-6 flex items-center justify-center flex-shrink-0`}
                  style={{ width: "120px", height: "120px" }}
                >
                  <Icon className="h-16 w-16 text-white" strokeWidth={1.5} />
                </div>

                <div className="flex-1 space-y-3">
                  <div>
                    <h3 className="font-bold text-lg mb-1">{model.name}</h3>
                    <div className="flex flex-wrap gap-1">
                      {model.hazards.map((hazard, i) => (
                        <Badge
                          key={i}
                          variant="secondary"
                          className="text-xs"
                        >
                          {hazard}
                        </Badge>
                      ))}
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-2 text-xs">
                    <div className="flex items-center gap-1">
                      <DollarSign className="h-3 w-3 text-muted-foreground" />
                      <span className="text-muted-foreground">
                        {model.cost}
                      </span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Shield className="h-3 w-3 text-green-600" />
                      <span className="font-bold text-green-600">
                        {model.resilience}%
                      </span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Wrench className="h-3 w-3 text-muted-foreground" />
                      <span className="text-muted-foreground">
                        {model.complexity}
                      </span>
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      variant="outline"
                      className="flex-1"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/model/${model.id}`);
                      }}
                    >
                      Preview
                    </Button>
                    <Button
                      size="sm"
                      className="flex-1 bg-accent hover:bg-accent/90 text-white"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/construction/${model.id}`);
                      }}
                    >
                      Select
                      <ChevronRight className="ml-1 h-3 w-3" />
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
