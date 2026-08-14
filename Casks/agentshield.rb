cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1850"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1850/agentshield_0.2.1850_darwin_amd64.tar.gz"
      sha256 "e29f9501e36b616b56d9ffed1ef992ce64a8060f9f813269d72d8ba8076b7e06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1850/agentshield_0.2.1850_darwin_arm64.tar.gz"
      sha256 "dab0da1c39c43ba77fb6686ad2051663780fba89801e63be213c067cbbc12749"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1850/agentshield_0.2.1850_linux_amd64.tar.gz"
      sha256 "c90540489aa5363e6dc5eeda3cd7e6df8f2610595f3885c5a4b54d1948ec3197"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1850/agentshield_0.2.1850_linux_arm64.tar.gz"
      sha256 "2df00162b1c8f16756331c73c72edf2a4daf2546301bfed1885ac4b488ff63fb"
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
