cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.126"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.126/agentshield_0.2.126_darwin_amd64.tar.gz"
      sha256 "6436956fb61237385ee2529a78e633de1c4908ddced083cca3eff18569384e10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.126/agentshield_0.2.126_darwin_arm64.tar.gz"
      sha256 "f573ade15ef3fb70498f1e0caeecf39560335445ce2b96c627f90e1321220f52"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.126/agentshield_0.2.126_linux_amd64.tar.gz"
      sha256 "3d8b8d55345c4afceeb423634b823116ec78644cfca7f84ae6b7dc4ba76c6112"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.126/agentshield_0.2.126_linux_arm64.tar.gz"
      sha256 "f5fc5dd0ec1cf1c33bd5f45e189e775201be1f971e2f40a2fc8f8713306c6083"
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
