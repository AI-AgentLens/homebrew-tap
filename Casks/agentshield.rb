cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1465"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1465/agentshield_0.2.1465_darwin_amd64.tar.gz"
      sha256 "ee8c1a7d8e78f751ff8210fa80a1ecd74a186fd3bbd70b6983f6724bbf7556c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1465/agentshield_0.2.1465_darwin_arm64.tar.gz"
      sha256 "d67b393dd88db152f3cafd5294fe19af07fff72d055fbe40dcc356753e7a1cf0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1465/agentshield_0.2.1465_linux_amd64.tar.gz"
      sha256 "5e19bb92bc48141f9d1c989e416280e43d9566eaf59746115d20c88f306d3750"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1465/agentshield_0.2.1465_linux_arm64.tar.gz"
      sha256 "f38c62f554751301228bab3ca4a2cb44a91b49eb48fe9e62c55a7e53aa1033c6"
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
