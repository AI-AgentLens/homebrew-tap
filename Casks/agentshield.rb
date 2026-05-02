cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.856"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.856/agentshield_0.2.856_darwin_amd64.tar.gz"
      sha256 "e1561effcf6c29569b565e55e3edf102689a6d5caefe74d919e6bc1238ea6c78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.856/agentshield_0.2.856_darwin_arm64.tar.gz"
      sha256 "799456dce00e77791b66fd48fbfea04bf83fdc11cb05b7a1232e5ba82bd2b78e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.856/agentshield_0.2.856_linux_amd64.tar.gz"
      sha256 "92570c71880d1767e16da6ebea9c07769ae80828c01b219aabe173ad3fdf0e77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.856/agentshield_0.2.856_linux_arm64.tar.gz"
      sha256 "052b15d1ebe903f1607103014be46eefab9a13eba70dfcd88d2ef0e27d1deb5d"
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
