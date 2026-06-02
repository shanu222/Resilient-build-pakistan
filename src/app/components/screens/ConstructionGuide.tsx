import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Play,
  Pause,
  RotateCw,
  Maximize2,
  Layers,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { Button } from "../ui/button";
import { Card } from "../ui/card";
import { Progress } from "../ui/progress";
import { Slider } from "../ui/slider";

export function ConstructionGuide() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentPhase, setCurrentPhase] = useState(0);
  const [speed, setSpeed] = useState([1]);

  const phases = [
    { name: "Site Layout", duration: "2-3 days", color: "bg-gray-500" },
    { name: "Excavation", duration: "3-5 days", color: "bg-amber-700" },
    { name: "Foundation", duration: "7-10 days", color: "bg-stone-600" },
    { name: "Footings", duration: "5-7 days", color: "bg-slate-700" },
    { name: "Columns", duration: "10-14 days", color: "bg-zinc-600" },
    { name: "Beams", duration: "7-10 days", color: "bg-neutral-600" },
    { name: "Slab", duration: "14-21 days", color: "bg-gray-500" },
    { name: "Roof", duration: "10-14 days", color: "bg-red-700" },
    { name: "Drainage", duration: "5-7 days", color: "bg-blue-600" },
    { name: "Finishing", duration: "14-21 days", color: "bg-green-600" },
  ];

  const progress = ((currentPhase + 1) / phases.length) * 100;

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-4 shadow-lg">
        <h1 className="text-xl font-bold">Interactive Construction Guide</h1>
        <p className="text-sm text-white/70">Flood Resilient House</p>
      </div>

      <div className="p-4 space-y-4">
        <Card className="relative overflow-hidden bg-gradient-to-br from-slate-100 to-slate-200 aspect-[4/3]">
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center">
              <div
                className={`${phases[currentPhase].color} w-64 h-48 rounded-lg mx-auto mb-4 flex items-center justify-center shadow-2xl`}
              >
                <Layers className="h-24 w-24 text-white" strokeWidth={1} />
              </div>
              <p className="text-sm font-medium text-muted-foreground">
                {phases[currentPhase].name} Phase
              </p>
            </div>
          </div>

          <div className="absolute top-4 right-4 flex gap-2">
            <Button size="icon" variant="secondary" className="rounded-full">
              <RotateCw className="h-4 w-4" />
            </Button>
            <Button size="icon" variant="secondary" className="rounded-full">
              <Maximize2 className="h-4 w-4" />
            </Button>
            <Button
              size="icon"
              variant="secondary"
              className="rounded-full"
              onClick={() => navigate(`/engineering/column`)}
            >
              <Layers className="h-4 w-4" />
            </Button>
          </div>
        </Card>

        <Card className="p-6 space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="font-bold">{phases[currentPhase].name}</h3>
            <span className="text-sm text-muted-foreground">
              {phases[currentPhase].duration}
            </span>
          </div>
          <Progress value={progress} className="h-2" />
          <div className="flex justify-center items-center gap-4">
            <Button
              size="icon"
              variant="outline"
              onClick={() => setCurrentPhase(Math.max(0, currentPhase - 1))}
              disabled={currentPhase === 0}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>

            <Button
              size="icon"
              className="bg-accent hover:bg-accent/90 text-white w-16 h-16 rounded-full"
              onClick={() => setIsPlaying(!isPlaying)}
            >
              {isPlaying ? (
                <Pause className="h-6 w-6" />
              ) : (
                <Play className="h-6 w-6 ml-0.5" />
              )}
            </Button>

            <Button
              size="icon"
              variant="outline"
              onClick={() =>
                setCurrentPhase(Math.min(phases.length - 1, currentPhase + 1))
              }
              disabled={currentPhase === phases.length - 1}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>

          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>Playback Speed</span>
              <span>{speed[0]}x</span>
            </div>
            <Slider
              value={speed}
              onValueChange={setSpeed}
              min={0.5}
              max={2}
              step={0.5}
              className="w-full"
            />
          </div>
        </Card>

        <div>
          <h3 className="font-bold mb-3">Construction Timeline</h3>
          <div className="space-y-2">
            {phases.map((phase, index) => (
              <Card
                key={index}
                className={`p-4 cursor-pointer transition-all ${
                  index === currentPhase
                    ? "border-2 border-accent shadow-lg"
                    : "opacity-60 hover:opacity-100"
                }`}
                onClick={() => setCurrentPhase(index)}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`${phase.color} w-3 h-3 rounded-full`}
                  ></div>
                  <div className="flex-1">
                    <div className="flex justify-between items-center">
                      <span className="font-medium">{phase.name}</span>
                      <span className="text-xs text-muted-foreground">
                        {phase.duration}
                      </span>
                    </div>
                  </div>
                  {index < currentPhase && (
                    <span className="text-green-600 text-sm">✓</span>
                  )}
                </div>
              </Card>
            ))}
          </div>
        </div>

        <Card className="p-6 bg-blue-50 border-blue-200">
          <h3 className="font-bold mb-2 flex items-center gap-2">
            <Layers className="h-5 w-5 text-blue-600" />
            Phase Details: {phases[currentPhase].name}
          </h3>
          <p className="text-sm text-muted-foreground">
            Tap any component in the 3D view to see detailed engineering specifications, common mistakes, and inspection checklists.
          </p>
          <Button
            variant="outline"
            className="w-full mt-4"
            onClick={() => navigate(`/engineering/column`)}
          >
            View Engineering Details
          </Button>
        </Card>
      </div>
    </div>
  );
}
