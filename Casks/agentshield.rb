cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1459"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1459/agentshield_0.2.1459_darwin_amd64.tar.gz"
      sha256 "2a1521997a081276b2152051ba707e6fe2e6d3ad4d30c1e7cb8c2df552edc093"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1459/agentshield_0.2.1459_darwin_arm64.tar.gz"
      sha256 "a460349578dbe2a4e50558c4c30c7414d141d9030d66543959912869d41e89b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1459/agentshield_0.2.1459_linux_amd64.tar.gz"
      sha256 "ea5ca75b69123537ff00b91930305702ead96c8f3a5a4de24057438cf24579f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1459/agentshield_0.2.1459_linux_arm64.tar.gz"
      sha256 "bb58fa227638c26a7fbc2e40fcf938c461c8513f6350748aec4d32815f0665cf"
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
