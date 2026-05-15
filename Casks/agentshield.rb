cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.983"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.983/agentshield_0.2.983_darwin_amd64.tar.gz"
      sha256 "eca206766737f5f78bb9ae8ec02191c89ca7d85568ce82c8660cd50acd9ab41a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.983/agentshield_0.2.983_darwin_arm64.tar.gz"
      sha256 "fd511e7ba4b79b7749eb32b37dec42f33d21959533e687a80aadd7e2b247c82e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.983/agentshield_0.2.983_linux_amd64.tar.gz"
      sha256 "66cfad65209da965eedf05d21f7e8c9e5def4fa0dd71258e3e4da143447a32cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.983/agentshield_0.2.983_linux_arm64.tar.gz"
      sha256 "97592e3343672ae38d9dd09cec0195f93a2bae6119da5122ae51777c4abe43a2"
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
