cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.269"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.269/agentshield_0.2.269_darwin_amd64.tar.gz"
      sha256 "21dd5f0982ef72c518b8976dd4e40c2c940ae905e0dbe4ed9ffa08ac4f9e6438"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.269/agentshield_0.2.269_darwin_arm64.tar.gz"
      sha256 "d5d5277106ca83fe096dcfa04be593052d03bcfc70b7250c5f2a23e4add74194"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.269/agentshield_0.2.269_linux_amd64.tar.gz"
      sha256 "2c38103cf1bfbd7ec0e22d76fae42bb5953369cee736c23648724edd39a43c22"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.269/agentshield_0.2.269_linux_arm64.tar.gz"
      sha256 "b0a4466b3ec7a5a4c41f0de08680a33b47c325212ce255e6903c6699a4025dc4"
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
