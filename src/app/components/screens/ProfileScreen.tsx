import { User, MapPin, Building2, Download, Award, Settings, LogOut } from "lucide-react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";
import { Avatar, AvatarFallback } from "../ui/avatar";

export function ProfileScreen() {
  const userRoles = [
    { value: "citizen", label: "Citizen" },
    { value: "engineer", label: "Engineer" },
    { value: "contractor", label: "Contractor" },
    { value: "government", label: "Government Officer" },
    { value: "student", label: "Student" },
  ];

  const stats = [
    { label: "Saved Models", value: "3", icon: Building2 },
    { label: "Saved Locations", value: "5", icon: MapPin },
    { label: "Downloads", value: "12", icon: Download },
    { label: "Certificates", value: "0", icon: Award },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="relative h-32 bg-gradient-to-r from-[#0f172a] to-[#1e293b]"></div>

      <div className="px-6 -mt-16 pb-6 space-y-6">
        <Card className="p-6">
          <div className="flex items-center gap-4 mb-4">
            <Avatar className="h-20 w-20 border-4 border-background">
              <AvatarFallback className="bg-orange text-white text-2xl">
                <User className="h-10 w-10" />
              </AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <h2 className="text-xl font-bold">Construction Professional</h2>
              <p className="text-sm text-muted-foreground">user@example.com</p>
              <Badge className="mt-2 bg-blue-600">Citizen</Badge>
            </div>
          </div>
        </Card>

        <div className="grid grid-cols-2 gap-4">
          {stats.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <Card key={index} className="p-4 text-center">
                <Icon className="h-6 w-6 mx-auto mb-2 text-muted-foreground" />
                <p className="text-2xl font-bold">{stat.value}</p>
                <p className="text-xs text-muted-foreground">{stat.label}</p>
              </Card>
            );
          })}
        </div>

        <div>
          <h3 className="font-bold mb-3">Select User Role</h3>
          <div className="space-y-2">
            {userRoles.map((role) => (
              <Card
                key={role.value}
                className={`p-4 cursor-pointer transition-all ${
                  role.value === "citizen"
                    ? "border-2 border-accent bg-accent/5"
                    : "hover:bg-muted"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                      role.value === "citizen"
                        ? "border-accent"
                        : "border-muted-foreground"
                    }`}
                  >
                    {role.value === "citizen" && (
                      <div className="w-3 h-3 bg-accent rounded-full"></div>
                    )}
                  </div>
                  <span className="font-medium">{role.label}</span>
                </div>
              </Card>
            ))}
          </div>
        </div>

        <div>
          <h3 className="font-bold mb-3">Quick Links</h3>
          <div className="space-y-2">
            <Button variant="outline" className="w-full justify-start">
              <Building2 className="h-4 w-4 mr-3" />
              Saved Models
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <MapPin className="h-4 w-4 mr-3" />
              Saved Locations
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <Download className="h-4 w-4 mr-3" />
              Downloaded Documents
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <Award className="h-4 w-4 mr-3" />
              Certificates
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <Settings className="h-4 w-4 mr-3" />
              Settings
            </Button>
          </div>
        </div>

        <Button variant="destructive" className="w-full">
          <LogOut className="h-4 w-4 mr-2" />
          Logout
        </Button>

        <p className="text-xs text-center text-muted-foreground">
          ResilientBuild Pakistan v1.0.0
        </p>
      </div>
    </div>
  );
}
