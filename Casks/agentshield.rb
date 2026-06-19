cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1369"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1369/agentshield_0.2.1369_darwin_amd64.tar.gz"
      sha256 "cb97af7452a751aa1b6f08ce190a238141a793f41753bfe2f02d845af612d0cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1369/agentshield_0.2.1369_darwin_arm64.tar.gz"
      sha256 "53ba2ebfa8d0b7e6c061f27d9ff0521bdaf79e197cc8cec7fc03fcce1e68fe0e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1369/agentshield_0.2.1369_linux_amd64.tar.gz"
      sha256 "68824ea03d0e9690524c65d91bb06ca20176456610bac9b97eb77d3089704b83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1369/agentshield_0.2.1369_linux_arm64.tar.gz"
      sha256 "3aa3508498d893dc523ecf928b256e23dd426f27c6be19a8b55fe83fd3c97041"
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
