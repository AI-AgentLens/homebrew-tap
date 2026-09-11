cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2117"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2117/agentshield_0.2.2117_darwin_amd64.tar.gz"
      sha256 "3272e2311ab15060e42e1aae119ce795cc44aea879cf2cfc6ea21af5f33e9d41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2117/agentshield_0.2.2117_darwin_arm64.tar.gz"
      sha256 "d2d5c9ccfd0df724fa28d2c955177bccd8efa4779fcddd1505a693d610c0a23d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2117/agentshield_0.2.2117_linux_amd64.tar.gz"
      sha256 "d4b29f16166c26cb41102efb6c7c1324d163d9878b9b416ed2807898436131dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2117/agentshield_0.2.2117_linux_arm64.tar.gz"
      sha256 "836a43c5f951bf6ec654c7200bf20a7e646149a432e6f36f6b3186926439c34c"
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
