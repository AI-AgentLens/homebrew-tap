cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1434"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1434/agentshield_0.2.1434_darwin_amd64.tar.gz"
      sha256 "8a63efa83fa272c366cfff849efbbf06a040e7e401547a4b18f8015a634f5658"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1434/agentshield_0.2.1434_darwin_arm64.tar.gz"
      sha256 "9d1f1efc0ae29daf6044c5fbed4663eba6588467d2a317d900062e7e6b0479ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1434/agentshield_0.2.1434_linux_amd64.tar.gz"
      sha256 "270402c901c21a6fd82417c9847f34a5830e35b539662e52631075eb0b4f7578"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1434/agentshield_0.2.1434_linux_arm64.tar.gz"
      sha256 "3627960bd4970ca6495947ed544fbd477e33702f320b9ed1e170f8268859a89c"
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
