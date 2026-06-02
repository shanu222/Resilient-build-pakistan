import { useNavigate, useParams } from "react-router";
import { MapPin, Building2, Shield, Download, Share2 } from "lucide-react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";
import { Progress } from "../ui/progress";

export function ResilienceReport() {
  const navigate = useNavigate();
  const { id } = useParams();

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">Resilience Report</h1>
        <p className="text-sm text-white/70">Construction safety assessment</p>
      </div>

      <div className="p-6 space-y-6">
        <Card className="p-6 bg-gradient-to-br from-green-50 to-green-100 border-green-200">
          <div className="flex items-center gap-4 mb-4">
            <div className="bg-green-600 p-4 rounded-2xl">
              <Shield className="h-8 w-8 text-white" />
            </div>
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-green-900">92%</h2>
              <p className="text-sm text-green-700">Resilience Score</p>
            </div>
          </div>
          <Progress value={92} className="h-3 bg-green-200" />
        </Card>

        <Card className="p-5">
          <h3 className="font-bold mb-4 flex items-center gap-2">
            <MapPin className="h-5 w-5 text-orange" />
            Location
          </h3>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">City</span>
              <span className="font-medium">Lahore, Punjab</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Coordinates</span>
              <span className="font-medium">31.5204° N, 74.3587° E</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Site Suitability</span>
              <span className="font-medium">68% (Moderate)</span>
            </div>
          </div>
        </Card>

        <Card className="p-5">
          <h3 className="font-bold mb-4 flex items-center gap-2">
            <Building2 className="h-5 w-5 text-blue-600" />
            Selected Model
          </h3>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Model Type</span>
              <span className="font-medium">Flood Resilient House</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Construction Complexity</span>
              <span className="font-medium">Moderate</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Cost Category</span>
              <span className="font-medium">Medium</span>
            </div>
          </div>
        </Card>

        <Card className="p-5">
          <h3 className="font-bold mb-3">Hazards Covered</h3>
          <div className="flex flex-wrap gap-2">
            <Badge className="bg-blue-600">Flood</Badge>
            <Badge className="bg-cyan-600">Heavy Rain</Badge>
            <Badge className="bg-indigo-600">River Overflow</Badge>
          </div>
        </Card>

        <Card className="p-5">
          <h3 className="font-bold mb-3">Engineering Features</h3>
          <ul className="space-y-2 text-sm">
            <li className="flex items-start gap-2">
              <span className="text-green-600 mt-0.5">✓</span>
              <span>Raised foundation 1.5m above ground level</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-600 mt-0.5">✓</span>
              <span>Water-resistant materials for lower structure</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-600 mt-0.5">✓</span>
              <span>Proper drainage system with sump pump</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-600 mt-0.5">✓</span>
              <span>Elevated electrical and plumbing systems</span>
            </li>
          </ul>
        </Card>

        <Card className="p-5">
          <h3 className="font-bold mb-3">Construction Recommendations</h3>
          <div className="space-y-2 text-sm text-muted-foreground">
            <p>• Use M20 grade concrete for foundation and columns</p>
            <p>• Install proper waterproofing membrane</p>
            <p>• Ensure adequate drainage away from foundation</p>
            <p>• Use galvanized steel for all reinforcement</p>
            <p>• Regular inspection during monsoon season</p>
          </div>
        </Card>

        <div className="flex gap-3">
          <Button className="flex-1 bg-accent hover:bg-accent/90 text-white">
            <Download className="h-4 w-4 mr-2" />
            Export PDF
          </Button>
          <Button variant="outline" className="flex-1">
            <Share2 className="h-4 w-4 mr-2" />
            Share Report
          </Button>
        </div>

        <p className="text-xs text-center text-muted-foreground">
          Generated: June 1, 2026 • ResilientBuild Pakistan
        </p>
      </div>
    </div>
  );
}
