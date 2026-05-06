cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.890"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.890/agentshield_0.2.890_darwin_amd64.tar.gz"
      sha256 "285c4f6458d54767e84b9ade92621a4ed5a4032816fdcc5c0bf7275846f2029f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.890/agentshield_0.2.890_darwin_arm64.tar.gz"
      sha256 "7a604623f09b54935aa1480aa76d8f34be9fce1ff7d12e35439e9220cb1e7f1d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.890/agentshield_0.2.890_linux_amd64.tar.gz"
      sha256 "6bee4a22c33205ec08916570731f8aafd89624f9ee28f27379b9588d0ce1f8cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.890/agentshield_0.2.890_linux_arm64.tar.gz"
      sha256 "7483195da5b40b361117ed222f1755fdeb6bbcc8fb197b111813b5abf94c0120"
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
