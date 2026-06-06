cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1227"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1227/agentshield_0.2.1227_darwin_amd64.tar.gz"
      sha256 "51393f9e304ff00a90b8359ab3d41aae1f3508edf9f9264948f53c4c52b04646"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1227/agentshield_0.2.1227_darwin_arm64.tar.gz"
      sha256 "438f71e50c71cc863ddae0627213fc06845ebf313e5388e5ff9a8c4654567b6b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1227/agentshield_0.2.1227_linux_amd64.tar.gz"
      sha256 "58c07c6c254f088c4820dede258f613c7c1519d760bbfddefc7e043ce5dae5ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1227/agentshield_0.2.1227_linux_arm64.tar.gz"
      sha256 "8519135edf173a0bb2a11a6ea2aa0847ab31e8a103b0a126efc6be100fe42531"
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
