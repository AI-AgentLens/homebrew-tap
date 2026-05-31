cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1168"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1168/agentshield_0.2.1168_darwin_amd64.tar.gz"
      sha256 "a154fbd8485291d8436c05af4690c93f9286c49bf5231b6861acdd1df3d7e90f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1168/agentshield_0.2.1168_darwin_arm64.tar.gz"
      sha256 "7831285bc6816dc08420bea3cc0cdca9d12dc68c029bdc6668b70ff267ae8c01"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1168/agentshield_0.2.1168_linux_amd64.tar.gz"
      sha256 "a3393929348dace3c97985140953c97b9f6cd46ae9b204c57c11c57d7ddee062"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1168/agentshield_0.2.1168_linux_arm64.tar.gz"
      sha256 "b82e1295878b31d6473b31ea35538f9e3ddbc672bca8b04d9c8fe8213062e01d"
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
