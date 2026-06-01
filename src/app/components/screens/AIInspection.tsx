import { useState } from "react";
import { Camera, Upload, CheckCircle, AlertTriangle, XCircle, Image as ImageIcon } from "lucide-react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";

export function AIInspection() {
  const [hasImage, setHasImage] = useState(false);

  const mockResults = [
    {
      item: "Rebar Spacing",
      status: "pass",
      details: "Spacing within 150-200mm requirement",
      icon: CheckCircle,
      color: "text-green-600",
      bg: "bg-green-50",
    },
    {
      item: "Concrete Cover",
      status: "warning",
      details: "Cover appears thin in some areas (35mm detected, 40mm required)",
      icon: AlertTriangle,
      color: "text-orange",
      bg: "bg-orange/10",
    },
    {
      item: "Beam Dimensions",
      status: "pass",
      details: "Dimensions match specification (9\" x 12\")",
      icon: CheckCircle,
      color: "text-green-600",
      bg: "bg-green-50",
    },
    {
      item: "Column Detailing",
      status: "critical",
      details: "Missing ties detected in column section",
      icon: XCircle,
      color: "text-red-600",
      bg: "bg-red-50",
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">AI Site Inspection</h1>
        <p className="text-sm text-white/70">Upload construction photos for analysis</p>
      </div>

      <div className="p-6 space-y-6">
        {!hasImage ? (
          <Card className="p-12 border-2 border-dashed border-muted-foreground/30 hover:border-accent transition-colors cursor-pointer">
            <div className="text-center space-y-4">
              <div className="bg-muted rounded-full p-6 w-24 h-24 mx-auto flex items-center justify-center">
                <Camera className="h-12 w-12 text-muted-foreground" />
              </div>
              <div>
                <h3 className="font-bold mb-2">Upload Construction Photo</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Take a photo of rebar, columns, beams, or other structural elements
                </p>
              </div>
              <div className="flex gap-3 justify-center">
                <Button
                  className="bg-accent hover:bg-accent/90 text-white"
                  onClick={() => setHasImage(true)}
                >
                  <Camera className="h-4 w-4 mr-2" />
                  Take Photo
                </Button>
                <Button
                  variant="outline"
                  onClick={() => setHasImage(true)}
                >
                  <Upload className="h-4 w-4 mr-2" />
                  Upload Image
                </Button>
              </div>
            </div>
          </Card>
        ) : (
          <>
            <Card className="overflow-hidden">
              <div className="aspect-video bg-gradient-to-br from-slate-200 to-slate-300 flex items-center justify-center">
                <ImageIcon className="h-24 w-24 text-muted-foreground" />
              </div>
              <div className="p-4 bg-slate-50">
                <p className="text-sm text-muted-foreground">Uploaded: column_construction.jpg</p>
              </div>
            </Card>

            <Card className="p-6 bg-gradient-to-r from-blue-50 to-blue-100 border-blue-200">
              <h3 className="font-bold mb-2">AI Analysis Complete</h3>
              <p className="text-sm text-muted-foreground">
                4 items analyzed • 2 passed • 1 warning • 1 critical issue
              </p>
            </Card>

            <div>
              <h3 className="font-bold mb-4">Inspection Results</h3>
              <div className="space-y-3">
                {mockResults.map((result, index) => {
                  const Icon = result.icon;
                  return (
                    <Card key={index} className={`p-4 ${result.bg} border-2`}>
                      <div className="flex gap-3">
                        <Icon className={`h-5 w-5 ${result.color} flex-shrink-0 mt-0.5`} />
                        <div className="flex-1">
                          <div className="flex justify-between items-start mb-2">
                            <h4 className="font-bold">{result.item}</h4>
                            <Badge
                              className={
                                result.status === "pass"
                                  ? "bg-green-600"
                                  : result.status === "warning"
                                  ? "bg-orange"
                                  : "bg-red-600"
                              }
                            >
                              {result.status.toUpperCase()}
                            </Badge>
                          </div>
                          <p className="text-sm">{result.details}</p>
                        </div>
                      </div>
                    </Card>
                  );
                })}
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => setHasImage(false)}
              >
                Upload Another
              </Button>
              <Button
                className="flex-1 bg-accent hover:bg-accent/90 text-white"
              >
                Download Report
              </Button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
