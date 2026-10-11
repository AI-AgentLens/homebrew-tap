cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2407"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2407/agentshield_0.2.2407_darwin_amd64.tar.gz"
      sha256 "7fa029450c66d503b2103a63f8512b7b5850b84f0bee8e322c9529c2b2f196a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2407/agentshield_0.2.2407_darwin_arm64.tar.gz"
      sha256 "aaf4e9544d64f15e2f412cdd900270c36c1bfbb2806c703300ba8ce76567b236"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2407/agentshield_0.2.2407_linux_amd64.tar.gz"
      sha256 "302bbac6660660b863357ff2450ded0b7aa64a758c2c62ff8744df1639bac0e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2407/agentshield_0.2.2407_linux_arm64.tar.gz"
      sha256 "0e048bc391e7e8c88c5776371a339d011962cf6cec6aef9c80a0cb44a37390b2"
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
