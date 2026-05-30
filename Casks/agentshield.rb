cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1155"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1155/agentshield_0.2.1155_darwin_amd64.tar.gz"
      sha256 "0916ada6bd7ecaddfea9eddc089a07112b0de4e3e032bf53a35768cf15e79ef8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1155/agentshield_0.2.1155_darwin_arm64.tar.gz"
      sha256 "b2bf819413ff65707209677223c9ea6899a7a4958eb1c87275e19c66ad547004"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1155/agentshield_0.2.1155_linux_amd64.tar.gz"
      sha256 "652d5661f6c592433ef8e5f661b04c187984d3178373b6a6dc77a0a94f3232bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1155/agentshield_0.2.1155_linux_arm64.tar.gz"
      sha256 "fa0e772a66b863fdae84803493dbe3ed95523d32d72190bca3a700ffc02acb06"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
