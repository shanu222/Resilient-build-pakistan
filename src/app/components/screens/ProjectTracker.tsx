import { Plus, Calendar, Image as ImageIcon, FileText } from "lucide-react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Progress } from "../ui/progress";
import { Badge } from "../ui/badge";

export function ProjectTracker() {
  const projects = [
    {
      name: "House - Lahore",
      model: "Flood Resilient House",
      status: "Structure",
      progress: 65,
      startDate: "Jan 15, 2026",
      photos: 42,
    },
    {
      name: "House - Islamabad",
      model: "Earthquake Resistant House",
      status: "Foundation",
      progress: 30,
      startDate: "Mar 1, 2026",
      photos: 18,
    },
  ];

  const phases = [
    { name: "Planning", completed: true },
    { name: "Foundation", completed: true },
    { name: "Structure", completed: false },
    { name: "Roof", completed: false },
    { name: "Finishing", completed: false },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold mb-1">Project Tracker</h1>
            <p className="text-sm text-white/70">Manage your construction projects</p>
          </div>
          <Button size="icon" className="bg-orange hover:bg-orange/90 rounded-full">
            <Plus className="h-5 w-5" />
          </Button>
        </div>
      </div>

      <div className="p-6 space-y-6">
        {projects.length === 0 ? (
          <Card className="p-12 border-2 border-dashed border-muted-foreground/30">
            <div className="text-center space-y-4">
              <div className="bg-muted rounded-full p-6 w-24 h-24 mx-auto flex items-center justify-center">
                <Plus className="h-12 w-12 text-muted-foreground" />
              </div>
              <div>
                <h3 className="font-bold mb-2">No Projects Yet</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Start tracking your construction project
                </p>
              </div>
              <Button className="bg-accent hover:bg-accent/90 text-white">
                <Plus className="h-4 w-4 mr-2" />
                Create Project
              </Button>
            </div>
          </Card>
        ) : (
          <div className="space-y-4">
            {projects.map((project, index) => (
              <Card key={index} className="overflow-hidden hover:shadow-lg transition-all cursor-pointer">
                <div className="p-5 space-y-4">
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="font-bold text-lg">{project.name}</h3>
                      <p className="text-sm text-muted-foreground">{project.model}</p>
                    </div>
                    <Badge className="bg-blue-600">{project.status}</Badge>
                  </div>

                  <div>
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-muted-foreground">Overall Progress</span>
                      <span className="font-bold">{project.progress}%</span>
                    </div>
                    <Progress value={project.progress} className="h-2" />
                  </div>

                  <div className="grid grid-cols-3 gap-4 text-sm">
                    <div>
                      <p className="text-muted-foreground mb-1">Started</p>
                      <div className="flex items-center gap-1">
                        <Calendar className="h-3 w-3" />
                        <span className="font-medium">{project.startDate}</span>
                      </div>
                    </div>
                    <div>
                      <p className="text-muted-foreground mb-1">Photos</p>
                      <div className="flex items-center gap-1">
                        <ImageIcon className="h-3 w-3" />
                        <span className="font-medium">{project.photos}</span>
                      </div>
                    </div>
                    <div>
                      <p className="text-muted-foreground mb-1">Documents</p>
                      <div className="flex items-center gap-1">
                        <FileText className="h-3 w-3" />
                        <span className="font-medium">12</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex gap-2 overflow-x-auto pb-2">
                    {phases.map((phase, i) => (
                      <div
                        key={i}
                        className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs ${
                          phase.completed
                            ? "bg-green-100 text-green-700"
                            : "bg-muted text-muted-foreground"
                        }`}
                      >
                        {phase.completed && "✓ "}
                        {phase.name}
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
