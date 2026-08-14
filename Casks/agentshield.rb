cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1854"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1854/agentshield_0.2.1854_darwin_amd64.tar.gz"
      sha256 "2973ac4ede22e8964fb616c7c717660d93f4332061253c0ab6d368f9a6729a64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1854/agentshield_0.2.1854_darwin_arm64.tar.gz"
      sha256 "bb41cc62c889698552f2ec9bd6339ff1758be5d067169c36ce3a324b491e864a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1854/agentshield_0.2.1854_linux_amd64.tar.gz"
      sha256 "3223fd785a986ac9c3fa5b4a06aad67adc2d24d29961523069f68368aa5b13e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1854/agentshield_0.2.1854_linux_arm64.tar.gz"
      sha256 "2810f35ae1efc4ee9e810f00eed09ea73d6af84f29b9f59bae851bcfc4208713"
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
