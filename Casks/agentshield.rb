cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1936"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1936/agentshield_0.2.1936_darwin_amd64.tar.gz"
      sha256 "11fe01c600c54ee537cfa1028d023650efccbfcc161e9e8eb19268fd8f100fbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1936/agentshield_0.2.1936_darwin_arm64.tar.gz"
      sha256 "ea569642889e6ce6c82ef037006faea3acb0b72c9745f08d6f96ebff00be0d40"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1936/agentshield_0.2.1936_linux_amd64.tar.gz"
      sha256 "1cf1923da02a27acbdb167df34450ac2fd652b29c21f2b20592a7efeab46fe37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1936/agentshield_0.2.1936_linux_arm64.tar.gz"
      sha256 "31335dea1f63ad9d79ba05472de3e87d0b7cb1c64c69ee3afddba3cec3aa6528"
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
