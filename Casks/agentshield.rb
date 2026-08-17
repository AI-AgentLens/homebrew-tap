cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1886"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1886/agentshield_0.2.1886_darwin_amd64.tar.gz"
      sha256 "09e115fbe56284d657e41b342c4bcfcdc7ee0b580399fbbd62c5027e2192c758"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1886/agentshield_0.2.1886_darwin_arm64.tar.gz"
      sha256 "654f059911b31d0909e6059461efcf2723b321c0b4f772e5e57560b8ca8bc504"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1886/agentshield_0.2.1886_linux_amd64.tar.gz"
      sha256 "4719223042dac122961dfb93e71886d965591a759d7c6d4ba209e3cb49f51cdc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1886/agentshield_0.2.1886_linux_arm64.tar.gz"
      sha256 "a8c3c37a7f7f29858786a05c282bd2f2a755a045296d0cc807e9d674e2c54b23"
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
