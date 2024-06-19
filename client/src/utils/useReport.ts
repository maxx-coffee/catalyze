import { useEffect, useState } from "react";
import { socket } from "./socket";
import { Channel } from "phoenix";

export const useReport: () => Channel | null = () => {
  const [report, setReport] = useState<null | Channel>(null);
  useEffect(() => {    
    if (!socket) return;
    const reportChannel = socket.channel("report:lobby", {});
    reportChannel.join().receive("ok", () => {
      setReport(reportChannel);
    });

    reportChannel.on("new_report", (payload) => {
      console.log("new report", payload);
    });
    return () => {
      reportChannel.leave();
    };
  }, []);
  return report;
}