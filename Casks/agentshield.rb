cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1870"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1870/agentshield_0.2.1870_darwin_amd64.tar.gz"
      sha256 "18a3265238540979d5ae0b68f6224b924265d23d045d4015e4210fafb094eb75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1870/agentshield_0.2.1870_darwin_arm64.tar.gz"
      sha256 "324ba64b3db5bbc1d8d3e62bd4709dbbdaf8591d8307f4a97f1369d769792cd2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1870/agentshield_0.2.1870_linux_amd64.tar.gz"
      sha256 "d9e5825628dd451490feae0335a533dfdc668034b31294ff74b4cc78181d722b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1870/agentshield_0.2.1870_linux_arm64.tar.gz"
      sha256 "562900111ec91231b524628d2e0f87e09122e48ee5c3ea69c9b12d4a3d4d6c94"
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
