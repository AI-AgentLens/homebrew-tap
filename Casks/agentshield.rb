cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1260"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1260/agentshield_0.2.1260_darwin_amd64.tar.gz"
      sha256 "46b9ce0efcdeb1ae8797d43e92ce79a10dba5e997f9de79db0891b40a362d923"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1260/agentshield_0.2.1260_darwin_arm64.tar.gz"
      sha256 "bc562ed7c39aa66f6bd0be2857a01c9fa1fe5ee903c62e5a4dccde9bcd2ff5ba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1260/agentshield_0.2.1260_linux_amd64.tar.gz"
      sha256 "eb170c2b3138c0f34743424878eff9a21b79f2b7e8d7cfddfddf75a53c23d80f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1260/agentshield_0.2.1260_linux_arm64.tar.gz"
      sha256 "d8b4a620453b7eb2c65fb537a090e1874438e319c11729f5ce3d50f2631d63d9"
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
