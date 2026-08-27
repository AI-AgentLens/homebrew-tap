cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1963"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1963/agentshield_0.2.1963_darwin_amd64.tar.gz"
      sha256 "027ae068e23521c50969dd92db32fd3cc1713814e8b04ccfc9a603bd0ff6284c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1963/agentshield_0.2.1963_darwin_arm64.tar.gz"
      sha256 "e67df71018a401320380d6ab957d61afdcdec925a78fb8856d3d908f9c26ffbd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1963/agentshield_0.2.1963_linux_amd64.tar.gz"
      sha256 "c9fa4067e7940cae1a77854996d1b3f0cbd7e2548f439afe2821d496591d2866"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1963/agentshield_0.2.1963_linux_arm64.tar.gz"
      sha256 "b9e146f93163cdd9e120c8b99241924ea90396f0760195d5e27609e10ea546df"
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
