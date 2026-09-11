cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2111"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2111/agentshield_0.2.2111_darwin_amd64.tar.gz"
      sha256 "34e23fd99d6ab1bf5b744f925bf93914e1b1212b18ecfc17e87e45890c127332"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2111/agentshield_0.2.2111_darwin_arm64.tar.gz"
      sha256 "82ba28810ff7e5d1571c555d4b9fcbd2e2ddd05cd5c34396ebba375fe9dfd663"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2111/agentshield_0.2.2111_linux_amd64.tar.gz"
      sha256 "c9d533a2ba11111c7a0ba18ffd1802a22635129a976d472b435a3c7ea4955f86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2111/agentshield_0.2.2111_linux_arm64.tar.gz"
      sha256 "0346c72066a072a11bd2ee95f756b7571fa3a6427593c7675cd4c29e0d24065b"
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
