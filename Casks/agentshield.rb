cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.127"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.127/agentshield_0.2.127_darwin_amd64.tar.gz"
      sha256 "374f25ee8a2b9afd5bd4dea944c37ceb4255bbdf8e90c361ad110664c7a2b066"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.127/agentshield_0.2.127_darwin_arm64.tar.gz"
      sha256 "601c221eb2ee6a35eca7b542f4126902b86f1e87761bee4c4ec80fbbf993dad3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.127/agentshield_0.2.127_linux_amd64.tar.gz"
      sha256 "8d027d8cdf1f609ffa4043080c775303542798f673828fe4da19f20e390b5478"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.127/agentshield_0.2.127_linux_arm64.tar.gz"
      sha256 "e91cad5ce769cb97954196488fdbec1fbb332c7112cab6b9d0fce85eee9cf7eb"
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
