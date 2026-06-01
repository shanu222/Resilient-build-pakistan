import { User, Hammer, Briefcase, HardHat, Shield, Trophy, Play } from "lucide-react";
import { Card } from "../ui/card";
import { Progress } from "../ui/progress";
import { Badge } from "../ui/badge";
import { Button } from "../ui/button";

export function ConstructionAcademy() {
  const learningPaths = [
    {
      title: "Citizen Mode",
      icon: User,
      color: "bg-blue-600",
      description: "Learn construction basics for homeowners",
      lessons: 12,
      progress: 0,
    },
    {
      title: "Mason Mode",
      icon: Hammer,
      color: "bg-orange",
      description: "Technical training for construction workers",
      lessons: 24,
      progress: 0,
    },
    {
      title: "Contractor Mode",
      icon: Briefcase,
      color: "bg-purple-600",
      description: "Project management and quality control",
      lessons: 18,
      progress: 0,
    },
    {
      title: "Engineer Mode",
      icon: HardHat,
      color: "bg-green-600",
      description: "Advanced structural engineering concepts",
      lessons: 32,
      progress: 0,
    },
    {
      title: "Government Inspector Mode",
      icon: Shield,
      color: "bg-red-600",
      description: "Code compliance and safety inspection",
      lessons: 15,
      progress: 0,
    },
  ];

  const featuredCourses = [
    {
      title: "Foundation Construction Basics",
      duration: "45 min",
      lessons: 8,
      level: "Beginner",
    },
    {
      title: "Earthquake-Resistant Design",
      duration: "2 hours",
      lessons: 12,
      level: "Intermediate",
    },
    {
      title: "Flood Mitigation Techniques",
      duration: "1.5 hours",
      lessons: 10,
      level: "Intermediate",
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">Construction Academy</h1>
        <p className="text-sm text-white/70">Learn resilient building practices</p>
      </div>

      <div className="p-6 space-y-6">
        <Card className="p-6 bg-gradient-to-r from-green-50 to-green-100 border-green-200">
          <div className="flex items-center gap-3">
            <Trophy className="h-8 w-8 text-green-600" />
            <div>
              <h3 className="font-bold">Your Progress</h3>
              <p className="text-sm text-muted-foreground">0 courses completed • 0 certificates earned</p>
            </div>
          </div>
        </Card>

        <div>
          <h3 className="font-bold mb-4">Choose Your Learning Path</h3>
          <div className="space-y-3">
            {learningPaths.map((path, index) => {
              const Icon = path.icon;
              return (
                <Card key={index} className="p-5 hover:shadow-lg transition-all cursor-pointer">
                  <div className="flex gap-4">
                    <div className={`${path.color} p-4 rounded-2xl flex-shrink-0`}>
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-bold mb-1">{path.title}</h4>
                      <p className="text-sm text-muted-foreground mb-3">
                        {path.description}
                      </p>
                      <div className="flex items-center justify-between text-sm mb-2">
                        <span className="text-muted-foreground">{path.lessons} lessons</span>
                        <span className="font-medium">{path.progress}%</span>
                      </div>
                      <Progress value={path.progress} className="h-2" />
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </div>

        <div>
          <h3 className="font-bold mb-4">Featured Courses</h3>
          <div className="space-y-3">
            {featuredCourses.map((course, index) => (
              <Card key={index} className="p-4">
                <div className="flex justify-between items-start mb-3">
                  <h4 className="font-bold">{course.title}</h4>
                  <Badge variant="secondary">{course.level}</Badge>
                </div>
                <div className="flex items-center justify-between text-sm text-muted-foreground mb-3">
                  <span>{course.lessons} lessons</span>
                  <span>{course.duration}</span>
                </div>
                <Button size="sm" className="w-full bg-accent hover:bg-accent/90 text-white">
                  <Play className="h-3 w-3 mr-2" />
                  Start Learning
                </Button>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
