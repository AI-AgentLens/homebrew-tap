cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.804"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.804/agentshield_0.2.804_darwin_amd64.tar.gz"
      sha256 "79e522ecf539dfac5d465073c4c15a4d6fa3422cee96a6e3cddb07d7f1c0a04f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.804/agentshield_0.2.804_darwin_arm64.tar.gz"
      sha256 "22ab8f0302174abbc69744e95c7d3296d7282021d8c9e75497a246f7ebb3c599"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.804/agentshield_0.2.804_linux_amd64.tar.gz"
      sha256 "e85e822843aa7fdff4c5595d382bcbe0c959b421ffcb95e7fab76126d1584eee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.804/agentshield_0.2.804_linux_arm64.tar.gz"
      sha256 "53472d6c5b86dfaf129048bf4f8cddabbc91166087c8e6a7ddab0f7a1b20bd37"
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
