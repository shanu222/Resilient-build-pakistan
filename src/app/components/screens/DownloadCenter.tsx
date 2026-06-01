import { FileText, Download, FileSpreadsheet, Image } from "lucide-react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";

export function DownloadCenter() {
  const downloads = [
    {
      title: "Construction Guidelines PDF",
      description: "Complete construction manual for flood-resilient houses",
      size: "12.5 MB",
      type: "PDF",
      icon: FileText,
      color: "bg-red-500",
    },
    {
      title: "Structural Drawings",
      description: "AutoCAD drawings with detailed dimensions",
      size: "8.2 MB",
      type: "DWG",
      icon: Image,
      color: "bg-blue-600",
    },
    {
      title: "BOQ Sample",
      description: "Bill of Quantities template for cost estimation",
      size: "1.8 MB",
      type: "XLSX",
      icon: FileSpreadsheet,
      color: "bg-green-600",
    },
    {
      title: "Inspection Checklists",
      description: "Quality control checklists for each construction phase",
      size: "2.1 MB",
      type: "PDF",
      icon: FileText,
      color: "bg-orange",
    },
    {
      title: "NDMA Resilience Guidelines",
      description: "Official disaster management construction standards",
      size: "15.3 MB",
      type: "PDF",
      icon: FileText,
      color: "bg-purple-600",
    },
    {
      title: "Engineering Standards",
      description: "BCP SP-07 code references and specifications",
      size: "9.7 MB",
      type: "PDF",
      icon: FileText,
      color: "bg-slate-600",
    },
    {
      title: "Offline Learning Package",
      description: "Complete course materials for offline access",
      size: "125 MB",
      type: "ZIP",
      icon: FileText,
      color: "bg-cyan-600",
    },
  ];

  return (
    <div className="h-full w-full bg-background overflow-auto pb-20">
      <div className="sticky top-0 z-10 bg-gradient-to-r from-[#0f172a] to-[#1e293b] text-white p-6 shadow-lg">
        <h1 className="text-2xl font-bold mb-1">Download Center</h1>
        <p className="text-sm text-white/70">Essential construction resources</p>
      </div>

      <div className="p-6 space-y-4">
        {downloads.map((item, index) => {
          const Icon = item.icon;
          return (
            <Card key={index} className="p-4 hover:shadow-lg transition-all">
              <div className="flex gap-4">
                <div className={`${item.color} p-4 rounded-xl flex-shrink-0`}>
                  <Icon className="h-6 w-6 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <h3 className="font-bold">{item.title}</h3>
                    <Badge variant="secondary" className="flex-shrink-0">{item.type}</Badge>
                  </div>
                  <p className="text-sm text-muted-foreground mb-3">
                    {item.description}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-muted-foreground">{item.size}</span>
                    <Button size="sm" className="bg-accent hover:bg-accent/90 text-white">
                      <Download className="h-3 w-3 mr-2" />
                      Download
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
